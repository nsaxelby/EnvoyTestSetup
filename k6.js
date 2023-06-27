import http from "k6/http";
import { sleep } from 'k6';
export const options = {
  iterations: 100000,
};

export default function () {
  var address = "http://my-nlb-542a7ae420daefa1.elb.eu-west-1.amazonaws.com"
  http.get(address + "/json");
  http.get(address + "/status/500");
  http.get(address + "/status/404");
  http.get(address + "/status/404");
  sleep(1);
}
