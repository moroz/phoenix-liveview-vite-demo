import { defineConfig } from "vite";
import postcssUrl from "postcss-url";

const BASE_URL = "http://localhost:3000";

// https://vitejs.dev/config/
export default defineConfig(({ command }: any) => {
  if (command !== "build") {
    // Terminate the watcher when Phoenix quits
    process.stdin.on("close", () => {
      process.exit(0);
    });

    process.stdin.resume();
  }

  return {
    base: "http://localhost:3000",
    publicDir: "static",
    build: {
      target: "esnext",
      outDir: "../priv/static", // phoenix expects our files here
      emptyOutDir: true, // cleanup previous builds
      sourcemap: true, // we want to debug our code in production
      rollupOptions: {
        input: {
          main: "./js/app.js"
        }
      }
    },
    css: {
      postcss: {
        plugins: [
          postcssUrl({
            url: (asset: any) => {
              if (asset.url.match(/^https?:\/\//)) return asset.url;
              const slash = asset.url.startsWith("/") ? "" : "/";
              return `${BASE_URL}${slash}${asset.url}`;
            }
          }) as any
        ]
      }
    }
  };
});
