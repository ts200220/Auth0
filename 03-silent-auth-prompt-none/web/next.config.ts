import type { NextConfig } from "next";

const nextConfig: NextConfig = {
  // hosts 経由の auth0-lab.local で dev 警告を抑える
  allowedDevOrigins: ["auth0-lab.local"],
  // Docker + バインドマウント向け
  webpack: (config, { dev }) => {
    if (dev) {
      config.watchOptions = {
        poll: 1000,
        aggregateTimeout: 300,
      };
    }
    return config;
  },
};

export default nextConfig;
