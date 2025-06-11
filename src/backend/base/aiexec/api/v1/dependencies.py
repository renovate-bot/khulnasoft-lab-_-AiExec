"""
Dependency module to provide easy access to core services and utilities throughout the API.
"""
from fastapi import Depends, Request
from .auth import get_current_user, AuthService
from .errors import ErrorHandler
from .middleware import CustomMiddleware
from .user_service import UserService

# Dependency to get the current authenticated user
def get_user(request: Request):
    return get_current_user(request)

# Dependency to get the AuthService instance
def get_auth_service():
    return AuthService()

# Dependency to get the UserService instance
def get_user_service():
    return UserService()

# Dependency to get the ErrorHandler instance
def get_error_handler():
    return ErrorHandler()

# Dependency to get the CustomMiddleware instance
def get_custom_middleware():
    return CustomMiddleware()

# Example usage in a router:
# from .dependencies import get_user_service
# @router.get("/users/me")
# def get_me(user_service: UserService = Depends(get_user_service)):
#     ...
