import http from "k6/http";
import { sleep } from 'k6';
export const options = {
  iterations: 100000,
};

export default function () {
  var address = "http://my-nlb-a04bea3cafb87905.elb.eu-west-1.amazonaws.com"
  http.get(address + "/json");
  http.get(address + "/status/500");
  http.get(address + "/status/404");
  http.get(address + "/status/404");
  sleep(1);
}

// while true; do date; curl -I --connect-timeout 2 http://my-nlb-dc49ff0dec232e99.elb.eu-west-1.amazonaws.com/json; sleep 1; done
