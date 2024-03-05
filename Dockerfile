FROM node:20-slim AS base
ENV PNPM_HOME="/pnpm"
ENV PATH="$PNPM_HOME:$PATH"
RUN corepack enable

RUN apt-get update && apt-get install -y git python3 make g++ pkg-config libxi-dev libxext-dev libx11-dev && ln -sf python3 /usr/bin/python

WORKDIR /app

# Use the ARG value here for git clone
RUN git clone https://github.com/Masutayunikon/Particule-life-js.git .

FROM base AS prod-deps
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --prod --frozen-lockfile

FROM base AS build
RUN --mount=type=cache,id=pnpm,target=/pnpm/store pnpm install --frozen-lockfile
RUN pnpm run build

FROM base
COPY --from=prod-deps /app/node_modules /app/node_modules
COPY --from=build /app/.output /app/.output
EXPOSE 3000

# node .output/server/index.mjs
CMD ["node", ".output/server/index.mjs"]

