import {
  PDFCheckFlow,
  PDFLoadErrorTitle,
} from "../../../../constants/constants";
import IconComponent from "../../../common/genericIconComponent";

export default function Error(): JSX.Element {
  return (
    <div className="flex h-full w-full flex-col items-center justify-center bg-muted">
      <div className="chat-alert-box">
        <span className="flex gap-2">
          <IconComponent name="FileX2" />
          <span className="aiexec-chat-span">{PDFLoadErrorTitle}</span>
        </span>
        <br />
        <div className="aiexec-chat-desc">
          <span className="aiexec-chat-desc-span">{PDFCheckFlow} </span>
        </div>
      </div>
    </div>
  );
}
