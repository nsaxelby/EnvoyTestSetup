import http from "k6/http";
import { sleep } from 'k6';
export const options = {
  iterations: 100000,
};

export default function () {
  const response =
    http.get("http://my-nlb-542a7ae420daefa1.elb.eu-west-1.amazonaws.com/json");
  sleep(1);
}
