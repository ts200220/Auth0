import type { NextConfig } from "next";

const nextConfig: NextConfig = {
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
