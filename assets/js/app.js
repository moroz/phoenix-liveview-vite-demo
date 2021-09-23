// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.sass";

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html";
// Establish Phoenix Socket and LiveView configuration.
import { Socket } from "phoenix";
import { LiveSocket } from "phoenix_live_view";

let csrfToken = document
  .querySelector("meta[name='csrf-token']")
  .getAttribute("content");

let liveSocket = new LiveSocket("/live", Socket, {
  params: { _csrf_token: csrfToken }
});

liveSocket.connect();

const activitySocket = new Socket("/activity", {
  params: { _csrf_token: csrfToken }
});

// connect if there are any LiveViews on the page
activitySocket.connect();

const channel = activitySocket.channel("activity:test");
channel.join();

setInterval(() => {
  channel.push("ping", {});
}, 3000);
