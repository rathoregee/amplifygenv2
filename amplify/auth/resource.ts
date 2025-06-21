import { defineAuth } from '@aws-amplify/backend';

/**
 * Define and configure your auth resource
 * @see https://docs.amplify.aws/gen2/build-a-backend/auth
 */

export const auth = defineAuth({
  loginWith: {
    email: true,
  },
  userAttributes: {
    // Maps to Cognito standard attribute 'address'
    address: {
      mutable: true,
      required: true,
    },
    // Maps to Cognito standard attribute 'birthdate'
    birthdate: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'email'
    email: {
      mutable: true,
      required: true,
    },
    // Maps to Cognito standard attribute 'family_name'
    familyName: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'gender'
    gender: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'given_name'
    givenName: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'locale'
    locale: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'middle_name'
    middleName: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'name'
    fullname: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'nickname'
    nickname: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'phone_number'
    phoneNumber: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'picture'
    profilePicture: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'preferred_username'
    preferredUsername: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'profile'
    profilePage: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'zoneinfo'
    timezone: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'updated_at'
    lastUpdateTime: {
      mutable: true,
      required: false,
    },
    // Maps to Cognito standard attribute 'website'
    website: {
      mutable: true,
      required: false,
    },
  },
});