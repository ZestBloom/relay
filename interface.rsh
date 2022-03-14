"reach 0.1";
"use strict";
// -----------------------------------------------
// Name: Interface Template
// Description: NP Rapp simple
// Author: Nicholas Shellabarger
// Version: 0.1.0 - relay initial
// Requires Reach v0.1.7 (stable)
// ----------------------------------------------
export const Participants = () => [Participant("Alice", {})];
export const Views = () => [
  View({
    owner: Address,
  }),
];
export const Api = () => [
  API({
    touch: Fun([], Null),
    update: Fun([Address], Null),
    flush: Fun([], Null),
    close: Fun([], Null),
  }),
];
export const App = (map) => {
  const [[Alice], [v], [a]] = map;
  Alice.publish();
  v.owner.set(Alice);
  const [keepGoing, owner] = parallelReduce([true, Alice])
    .define(() => {
      v.owner.set(owner);
    })
    .invariant(balance() >= 0)
    .while(keepGoing)
    .api(
      a.touch,
      () => assume(true),
      () => 100000,
      (k) => {
        require(true);
        k(null);
        return [keepGoing, owner];
      }
    )
    .api(
      a.update,
      (_) => assume(this === owner),
      (_) => 0,
      (addr, k) => {
        require(this === owner);
        k(null);
        return [keepGoing, addr];
      }
    )
    .api(
      a.flush,
      () => assume(this === owner),
      () => 0,
      (k) => {
        require(this === owner);
        transfer(balance()).to(owner);
        k(null);
        return [keepGoing, owner];
      }
    )
    .api(
      a.close,
      () => assume(this === owner),
      () => 0,
      (k) => {
        require(this === owner);
        k(null);
        return [false, owner];
      }
    )
    .timeout(false);
  transfer(balance()).to(owner);
  commit();
  exit();
};
// ----------------------------------------------
