import { factories } from '@strapi/strapi';

// Single type : seul find est pertinent (pas de findOne par id)
export default factories.createCoreRouter('api::configuration.configuration', {
  only: ['find'],
});
