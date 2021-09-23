import { Socket, Channel } from "phoenix";

export default class ActivityTracker {
  socket?: Socket;
  channel?: Channel;

  idle = true;
  interval?: number;

  constructor() {
    if (!document.body.classList.contains("track-activity")) return;

    let csrfToken = document
      .querySelector("meta[name='csrf-token']")
      ?.getAttribute("content");
    if (!csrfToken) return;

    this.socket = new Socket("/activity", {
      params: { _csrf_token: csrfToken }
    });

    this.socket.connect();

    this.channel = this.socket.channel("activity:track");
    this.channel.join();

    this.channel.on("logout", this.logOut);
    this.interval = window.setInterval(this.ping, 5000);

    ["mousemove", "scroll", "resize", "keydown"].forEach((ev) => {
      window.addEventListener(ev, this.handleActivity);
    });
  }

  async logOut() {
    await fetch("/users/log_out", {
      method: "DELETE",
      credentials: "include"
    });
    window.location.href = "/users/log_in";
  }

  ping = () => {
    if (!this.idle) {
      this.channel!.push("ping", {});
      this.idle = true;
    }
  };

  handleActivity = () => {
    if (this.idle) this.idle = false;
  };
}
