import type { Core } from '@strapi/strapi';

const config = ({ env }: Core.Config.Shared.ConfigParams): Core.Config.Plugin => ({
  documentation: {
    enabled: env('NODE_ENV') !== 'production',
    config: {
      openapi: '3.0.0',
      info: {
        title: '3C des 3 Caps API',
        version: '1.0.0',
        description: 'API REST en lecture seule — informations patients en cancérologie',
      },
    },
  },
});

export default config;
