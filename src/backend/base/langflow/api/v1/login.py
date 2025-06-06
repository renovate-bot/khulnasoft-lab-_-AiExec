from __future__ import annotations

from typing import Annotated

from fastapi import APIRouter, Depends, HTTPException, Request, Response, status
from fastapi.security import OAuth2PasswordRequestForm

from langflow.api.utils import DbSession
from langflow.api.v1.schemas import Token
from langflow.initial_setup.setup import get_or_create_default_folder
from langflow.services.deps import get_settings_service, get_variable_service

from .dependencies import get_auth_service, get_user_service
from .user_service import UserService
from .auth import AuthService

router = APIRouter(tags=["Login"])


@router.post("/login", response_model=Token)
async def login_to_get_access_token(
    response: Response,
    form_data: Annotated[OAuth2PasswordRequestForm, Depends()],
    db: DbSession,
    auth_service: AuthService = Depends(get_auth_service),
    user_service: UserService = Depends(get_user_service),
):
    auth_settings = get_settings_service().auth_settings
    try:
        user = await auth_service.authenticate_user(form_data.username, form_data.password, db)
    except Exception as exc:
        if isinstance(exc, HTTPException):
            raise
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=str(exc),
        ) from exc

    if user:
        tokens = await auth_service.create_user_tokens(user_id=user.id, db=db, update_last_login=True)
        response.set_cookie(
            "refresh_token_lf",
            tokens["refresh_token"],
            httponly=auth_settings.REFRESH_HTTPONLY,
            samesite=auth_settings.REFRESH_SAME_SITE,
            secure=auth_settings.REFRESH_SECURE,
            expires=auth_settings.REFRESH_TOKEN_EXPIRE_SECONDS,
            domain=auth_settings.COOKIE_DOMAIN,
        )
        response.set_cookie(
            "access_token_lf",
            tokens["access_token"],
            httponly=auth_settings.ACCESS_HTTPONLY,
            samesite=auth_settings.ACCESS_SAME_SITE,
            secure=auth_settings.ACCESS_SECURE,
            expires=auth_settings.ACCESS_TOKEN_EXPIRE_SECONDS,
            domain=auth_settings.COOKIE_DOMAIN,
        )
        response.set_cookie(
            "apikey_tkn_lflw",
            str(user.store_api_key),
            httponly=auth_settings.ACCESS_HTTPONLY,
            samesite=auth_settings.ACCESS_SAME_SITE,
            secure=auth_settings.ACCESS_SECURE,
            expires=None,  # Set to None to make it a session cookie
            domain=auth_settings.COOKIE_DOMAIN,
        )
        await user_service.initialize_user_variables(user.id, db)
        # Create default project for user if it doesn't exist
        _ = await get_or_create_default_folder(db, user.id)
        return tokens
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Incorrect username or password",
        headers={"WWW-Authenticate": "Bearer"},
    )


@router.get("/auto_login")
async def auto_login(response: Response, db: DbSession):
    auth_settings = get_settings_service().auth_settings

    if auth_settings.AUTO_LOGIN:
        user_id, tokens = await create_user_longterm_token(db)
        response.set_cookie(
            "access_token_lf",
            tokens["access_token"],
            httponly=auth_settings.ACCESS_HTTPONLY,
            samesite=auth_settings.ACCESS_SAME_SITE,
            secure=auth_settings.ACCESS_SECURE,
            expires=None,  # Set to None to make it a session cookie
            domain=auth_settings.COOKIE_DOMAIN,
        )

        user = await get_user_by_id(db, user_id)

        if user:
            if user.store_api_key is None:
                user.store_api_key = ""

            response.set_cookie(
                "apikey_tkn_lflw",
                str(user.store_api_key),  # Ensure it's a string
                httponly=auth_settings.ACCESS_HTTPONLY,
                samesite=auth_settings.ACCESS_SAME_SITE,
                secure=auth_settings.ACCESS_SECURE,
                expires=None,  # Set to None to make it a session cookie
                domain=auth_settings.COOKIE_DOMAIN,
            )

        return tokens

    raise HTTPException(
        status_code=status.HTTP_400_BAD_REQUEST,
        detail={
            "message": "Auto login is disabled. Please enable it in the settings",
            "auto_login": False,
        },
    )


@router.post("/refresh")
async def refresh_token(
    request: Request,
    response: Response,
    db: DbSession,
):
    auth_settings = get_settings_service().auth_settings

    token = request.cookies.get("refresh_token_lf")

    if token:
        tokens = await create_refresh_token(token, db)
        response.set_cookie(
            "refresh_token_lf",
            tokens["refresh_token"],
            httponly=auth_settings.REFRESH_HTTPONLY,
            samesite=auth_settings.REFRESH_SAME_SITE,
            secure=auth_settings.REFRESH_SECURE,
            expires=auth_settings.REFRESH_TOKEN_EXPIRE_SECONDS,
            domain=auth_settings.COOKIE_DOMAIN,
        )
        response.set_cookie(
            "access_token_lf",
            tokens["access_token"],
            httponly=auth_settings.ACCESS_HTTPONLY,
            samesite=auth_settings.ACCESS_SAME_SITE,
            secure=auth_settings.ACCESS_SECURE,
            expires=auth_settings.ACCESS_TOKEN_EXPIRE_SECONDS,
            domain=auth_settings.COOKIE_DOMAIN,
        )
        return tokens
    raise HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Invalid refresh token",
        headers={"WWW-Authenticate": "Bearer"},
    )


@router.post("/logout")
async def logout(response: Response):
    response.delete_cookie("refresh_token_lf")
    response.delete_cookie("access_token_lf")
    response.delete_cookie("apikey_tkn_lflw")
    return {"message": "Logout successful"}

@router.get("/me")
async def get_me(user_service: UserService = Depends(get_user_service)):
    user = await user_service.get_current_user()
    if not user:
        raise HTTPException(status_code=401, detail="Not authenticated")
    return {"user": user}

@router.post("/email-code-login")
async def email_code_login(
    request: Request,
    body: EmailCodeLoginRequest,
    auth_service: AuthService = Depends(get_auth_service),
    user_service: UserService = Depends(get_user_service),
):
    language = body.language if body.language == "zh-Hans" else "en-US"
    account = await user_service.get_user_by_email(body.email)
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")
    token = await auth_service.send_email_code_login_email(account=account, language=language)
    return {"result": "success", "data": token}

@router.post("/email-code-login/validity")
async def email_code_login_validity(
    request: Request,
    body: EmailCodeLoginValidityRequest,
    auth_service: AuthService = Depends(get_auth_service),
    user_service: UserService = Depends(get_user_service),
):
    app_code = request.headers.get("X-App-Code")
    if not app_code:
        raise HTTPException(status_code=400, detail="X-App-Code header is missing.")

    token_data = await auth_service.get_email_code_login_data(body.token)
    if not token_data:
        raise HTTPException(status_code=400, detail="Invalid token")
    if token_data["email"] != body.email:
        raise HTTPException(status_code=400, detail="Invalid email")
    if token_data["code"] != body.code:
        raise HTTPException(status_code=400, detail="Invalid code")

    await auth_service.revoke_email_code_login_token(body.token)
    account = await user_service.get_user_by_email(body.email)
    if not account:
        raise HTTPException(status_code=404, detail="Account not found")

    await auth_service.validate_user_accessibility(account=account, app_code=app_code)
    end_user = await auth_service.create_end_user(email=body.email, app_code=app_code)
    token = await auth_service.login(account=account, app_code=app_code, end_user_id=end_user.id)
    await user_service.reset_login_error_rate_limit(body.email)
    return {"result": "success", "token": token}

