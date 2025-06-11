---
title: Embedded chat widget
slug: /embedded-chat-widget
---

import Tabs from '@theme/Tabs';
import TabItem from '@theme/TabItem';
import ChatWidget from '@site/src/components/ChatWidget';

On the [Publish pane](/concepts-publish), the **Embed into site** tab displays code that can be inserted in the `<body>` of your HTML to interact with your flow.

The chat widget is implemented as a web component called `aiexec-chat` and is loaded from a CDN. For more information, see the [aiexec-embedded-chat repository](https://github.com/khulnasoft-lab/aiexec-embedded-chat).

For a sandbox example, see the [Aiexec embedded chat CodeSandbox](https://codesandbox.io/p/sandbox/aiexec-embedded-chat-example-dv9zpx).

The following example includes the minimum required inputs, called [props](https://react.dev/learn/passing-props-to-a-component) in React, for using the chat widget in your HTML code, which are `host_url` and `flow_id`.
The `host_url` value must be `HTTPS`, and may not include a `/` after the URL.
The `flow_id` value is found in your Aiexec URL.
For a Aiexec server running the [Basic prompting flow](/starter-projects-basic-prompting) at `https://c822-73-64-93-151.ngrok-free.app/flow/dcbed533-859f-4b99-b1f5-16fce884f28f`, your chat widget code is similar to the following:
```html
<html>
  <head>
    <script src="https://cdn.jsdelivr.net/gh/logspace-ai/aiexec-embedded-chat@main/dist/build/static/js/bundle.min.js"></script>
  </head>
  <body>
    <aiexec-chat
      host_url="https://c822-73-64-93-151.ngrok-free.app"
      flow_id="dcbed533-859f-4b99-b1f5-16fce884f28f"
    ></aiexec-chat>
  </body>
</html>
```

When this code is embedded within HTML, it becomes a responsive chatbot, powered by the basic prompting flow.

![Default chat widget](/img/chat-widget-default.png)

To configure your chat widget further, include additional props.

All props and their types are listed in [index.tsx](https://github.com/khulnasoft-lab/aiexec-embedded-chat/blob/main/src/index.tsx).

To add some styling to the chat widget, customize its elements with JSON:
```html
  <aiexec-chat
    host_url="https://c822-73-64-93-151.ngrok-free.app"
    flow_id="dcbed533-859f-4b99-b1f5-16fce884f28f"
    chat_window_style='{
      "backgroundColor": "#1a0d0d",
      "border": "4px solid #b30000",
      "borderRadius": "16px",
      "boxShadow": "0 8px 32px #b30000",
      "color": "#fff",
      "fontFamily": "Georgia, serif",
      "padding": "16px"
    }'
    window_title="Custom Styled Chat"
    height="600"
    width="400"
  ></aiexec-chat>
```

To add a custom [session ID](/session-id) value and an API key for authentication to your Aiexec server:
```html
<html>
  <head>
    <script src="https://cdn.jsdelivr.net/gh/logspace-ai/aiexec-embedded-chat@main/dist/build/static/js/bundle.min.js"></script>
  </head>
  <body>
    <aiexec-chat
      host_url="https://c822-73-64-93-151.ngrok-free.app"
      flow_id="dcbed533-859f-4b99-b1f5-16fce884f28f"
      api_key="YOUR_API_KEY"
      session_id="YOUR_SESSION_ID"
    ></aiexec-chat>
  </body>
</html>
```

The chat widget requires your flow to contain **Chat Input** and **Chat Output** components for the widget to communicate with it.
Sending a message to Aiexec without a **Chat Input** still triggers the flow, but the LLM warns you the message is empty.
**Text Input** and **Text Output** components can send and receive messages with Aiexec, but without the ongoing LLM "chat" context.

## Embed the chat widget with React

To use the chat widget in your React application, create a component that loads the widget script and renders the chat interface:

1. Declare your web component and encapsulate it in a React component.

```javascript
declare global {
  namespace JSX {
    interface IntrinsicElements {
      "aiexec-chat": any;
    }
  }
}

export default function ChatWidget({ className }) {
  return (
    <div className={className}>
      <aiexec-chat
        host_url="https://c822-73-64-93-151.ngrok-free.app"
        flow_id="dcbed533-859f-4b99-b1f5-16fce884f28f"
      ></aiexec-chat>
    </div>
  );
}
```
2. Place the component anywhere in your code to display the chat widget.

For example, in this docset, the React widget component is located at `docs > src > components > ChatWidget > index.tsx`.
`index.tsx` includes a script to load the chat widget code from CDN and initialize the `ChatWidget` component with props pointing to a Aiexec server.
```javascript
import React, { useEffect } from 'react';

// Component to load the chat widget script
const ChatScriptLoader = () => {
  useEffect(() => {
    if (!document.querySelector('script[src*="aiexec-embedded-chat"]')) {
      const script = document.createElement('script');
      script.src = 'https://cdn.jsdelivr.net/gh/khulnasoft-lab/aiexec-embedded-chat@main/dist/build/static/js/bundle.min.js';
      script.async = true;
      document.body.appendChild(script);
    }
  }, []);

  return null;
};

declare global {
  namespace JSX {
    interface IntrinsicElements {
      "aiexec-chat": any;
    }
  }
}

export default function ChatWidget({ className }) {
  return (
    <div className={className}>
      <ChatScriptLoader />
      <aiexec-chat
        host_url="https://c822-73-64-93-151.ngrok-free.app"
        flow_id="dcbed533-859f-4b99-b1f5-16fce884f28f"
      ></aiexec-chat>
    </div>
  );
}
```

3. To import the component to your page, add this to your site.
```
import ChatWidget from '@site/src/components/ChatWidget';
```
4. To add the widget to your page, include `<ChatWidget className="my-chat-widget" />`.

## Embed the chat widget with Angular

To use the chat widget in your [Angular](https://angular.dev/overview) application, create a component that loads the widget script and renders the chat interface.

Angular requires you to explicitly allow custom web components like `aiexec-chat` in components, so you must add the `<aiexec-chat>` element to your Angular template and configure Angular to recognize it. Add `CUSTOM_ELEMENTS_SCHEMA` to your module's configuration to enable this.

To add `CUSTOM_ELEMENTS_SCHEMA` to your module's configuration, do the following:

1. Open the module file `.module.ts` where you want to add the `aiexec-chat` web component.
2. Import `CUSTOM_ELEMENTS_SCHEMA` at the top of the `.module.ts` file:

`import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';`

3. Add `CUSTOM_ELEMENTS_SCHEMA` to the `schemas` array inside the `@NgModule` decorator:

```javascript
import { NgModule, CUSTOM_ELEMENTS_SCHEMA } from '@angular/core';
import { BrowserModule } from '@angular/platform-browser';
import { AppComponent } from './app.component';

@NgModule({
  declarations: [
    AppComponent
  ],
  imports: [
    BrowserModule
  ],
  schemas: [CUSTOM_ELEMENTS_SCHEMA],
  providers: [],
  bootstrap: [AppComponent]
})
export class AppModule { }
```

4. Add the chat widget to your component's template by including the `aiexec-chat` element in your component's `.component.ts` file:

For style properties that accept `JSON` objects like `chat_window_style` and `bot_message_style`, use Angular's property binding syntax `[propertyName]` to pass them as JavaScript objects.

```javascript
import { Component } from '@angular/core';

@Component({
  selector: 'app-root',
  template: `
    <div class="container">
      <h1>Aiexec Chat Test</h1>
      <aiexec-chat
        host_url="https://c822-73-64-93-151.ngrok-free.app"
        flow_id="dcbed533-859f-4b99-b1f5-16fce884f28f"
        [chat_window_style]='{"backgroundColor": "#ffffff"}'
        [bot_message_style]='{"color": "#000000"}'
        [user_message_style]='{"color": "#000000"}'
        window_title="Chat with us"
        placeholder="Type your message..."
        height="600"
        width="400"
        chat_position="bottom-right"
      ></aiexec-chat>
    </div>
  `,
  styles: [`
    .container {
      padding: 20px;
      text-align: center;
    }
  `]
})
export class AppComponent {
  title = 'Aiexec Chat Test';
}
```

## Chat widget configuration

Use the widget API to customize your chat widget.

Props with the type `JSON` need to be passed as stringified JSON, with the format \{"key":"value"\}.

All props and their types are listed in [index.tsx](https://github.com/khulnasoft-lab/aiexec-embedded-chat/blob/main/src/index.tsx).

| Prop                  | Type    | Description                                    |
|----------------------|---------|------------------------------------------------|
| flow_id              | String  | Required. Identifier for the flow associated with the component. |
| host_url             | String  | Required. URL of the host for communication with the chat component. |
| api_key              | String  | X-API-Key header to send to Aiexec. |
| additional_headers   | JSON    | Additional headers to be sent to the Aiexec server. |
| session_id           | String  | Custom session id to override the random session id. |
| height               | Number  | Height of the chat window in pixels. |
| width                | Number  | Width of the chat window in pixels. |
| chat_position        | String  | Position of chat window, such as `top-right` or `bottom-left`. |
| start_open           | Boolean | Whether the chat window should be open by default. |
| chat_window_style    | JSON    | Overall chat window appearance. |
| chat_trigger_style   | JSON    | Chat trigger button styling. |
| bot_message_style    | JSON    | Bot message formatting. |
| user_message_style   | JSON    | User message formatting. |
| error_message_style  | JSON    | Error message formatting. |
| input_style          | JSON    | Chat input field styling. |
| input_container_style| JSON    | Input container styling. |
| send_button_style    | JSON    | Send button styling. |
| send_icon_style      | JSON    | Send icon styling. |
| window_title         | String  | Title displayed in the chat window header. |
| placeholder          | String  | Placeholder text for the chat input field. |
| placeholder_sending  | String  | Placeholder text while sending a message. |
| online               | Boolean | Whether the chat component is online. |
| online_message       | String  | Custom message when chat is online. |
| input_type           | String  | Input type for chat messages. |
| output_type          | String  | Output type for chat messages. |
| output_component     | String  | Output ID when multiple outputs are present. |
| chat_output_key      | String  | Which output to display if multiple outputs are available. |
| tweaks               | JSON    | Additional custom adjustments for the flow. |