/**
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */
var config = {
  development: {
    ztshost: process.env.ZTS_SERVER || 'localhost',
    strictSSL: false,
    envLabel: '',
    loglevel: 'debug',
    zts_client_token_min_expiry_time: 900,
    zts_client_disable_cache: false,
  },
  production: {
    ztshost: process.env.ZTS_SERVER || 'localhost',
    strictSSL: true,
    envLabel: '',
    loglevel: 'info',
    zts_client_token_min_expiry_time: 900,
    zts_client_disable_cache: false,
  }
};

// Fetches 'service' specific config sub-section, and fills defaults if not present
module.exports = function() {
  var c = config[process.env.SERVICE_NAME || 'development'];

  c.ztshost = c.ztshost || 'localhost';
  c.zts = process.env.ZTS_SERVER_URL || 'https://' + c.ztshost + ':4443/zts/v1/',
  c.strictSSL = c.strictSSL || false;
  c.envLabel = c.envLabel || 'development';
  c.loglevel = c.loglevel || 'debug';
  c.zts_client_token_min_expiry_time = c.zts_client_token_min_expiry_time || 900;
  c.zts_client_disable_cache = c.zts_client_disable_cache || false;

  return c;
};
