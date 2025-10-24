import axios from 'axios';

export const api = axios.create({
  baseURL: 'https://api.omnimerhealth.com/v1',
  timeout: 10000,
});
