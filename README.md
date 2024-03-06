
Nuxt 3 Minimal Starter
======================

A minimal starter to get up and running with Nuxt 3. Explore the [Nuxt 3 documentation](https://nuxt.com/docs/getting-started/introduction) for more information.

Prerequisites
-------------

Before installing, make sure you have Node.js installed on your system. Find the appropriate installer for your system at [Node.js official website](https://nodejs.org/).

Setup
-----

First, clone the project using Git (if you have not done so already), then install the dependencies:

bash

Copy code

```
# npm 
npm install  

# pnpm 
pnpm install  

# yarn 
yarn install  

# bun 
bun install
```

Using Docker
------------

To build and run the project using Docker, make sure you have Docker installed on your system. Here's how you can build and run your Nuxt 3 application:

bash

Copy code

```
# Build your Docker image 
docker build -t nuxt3-starter .  

# Run your Docker container 
docker run -p 3000:3000 nuxt3-starter
```

This will serve your Nuxt 3 application on `http://localhost:3000`. The Docker commands assume that you have a Dockerfile in your project root and do not require cloning the GitHub repository.

Development Server
------------------

To start the development server:

bash

Copy code

```
# npm 
npm run dev  

# pnpm 
pnpm run dev  

# yarn 
yarn dev  

# bun 
bun run dev
```

Navigate to `http://localhost:3000` to view your application.

Production
----------

To build the application for production:

bash

Copy code

```
# npm 
npm run build  

# pnpm 
pnpm run build  

# yarn 
yarn build  

# bun 
bun run build
```

To locally preview the production build:

bash

Copy code

```
# npm 
npm run preview  

# pnpm 
pnpm run preview  

# yarn 
yarn preview  

# bun 
bun run preview
```

For more information on deployment, please consult the [Nuxt 3 deployment documentation](https://nuxt.com/docs/getting-started/deployment).

* * *
