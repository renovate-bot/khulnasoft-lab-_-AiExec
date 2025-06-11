import { AIEXEC_ACCESS_TOKEN } from "@/constants/constants";
import { Cookies } from "react-cookie";

export const customGetAccessToken = () => {
  const cookies = new Cookies();
  return cookies.get(AIEXEC_ACCESS_TOKEN);
};
