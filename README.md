# ODC handshake: a Tamarin model

This repository holds a symbolic model, in the [Tamarin prover](https://tamarin-prover.com), of the Open Driver Communication (ODC) handshake. ODC is the authenticated session between a key-management controller and a hardware security module (HSM) adapter. It is preliminary work for a research program on vendor-independent, crypto-agile management of heterogeneous HSMs.

## The protocol

1. C → D : C, D, nc, g^x, offer, where offer = ⟨hybrid, classical⟩
2. D → C : nd, g^y, v, sign_D(⟨ODC_D, C, D, nc, nd, g^x, g^y, offer, v⟩)
3. C → D : sign_C(⟨ODC_C, C, D, nc, nd, g^x, g^y, offer, v⟩)
   The session key is k = h(g^xy, nc, nd).
4. C → D : senc(⟨REQ, rid, op, keyhandle⟩, k). The device rejects a request id it has already seen.

There are two kinds of device. A hybrid-capable device picks the hybrid mode whenever it is offered. A legacy device supports classical only.

**Threat model:** Dolev–Yao network. The long-term key of any controller or device can be revealed at any time.

## Results (Tamarin 1.10.0, Maude 3.5, unbounded sessions)

| Lemma | Property | Result |
|---|---|---|
| executable | An honest run reaches operation execution | verified |
| key_secrecy_pfs | The session key stays secret; only compromise before acceptance breaks it (forward secrecy) | verified |
| device_key_secrecy | The same guarantee from the device's side | verified |
| controller_injective_agreement | The controller authenticates the device on the full transcript, one-to-one | verified |
| device_injective_agreement | The device authenticates the controller on the full transcript, one-to-one | verified |
| no_downgrade | A controller never settles on classical with a hybrid-capable device unless that device is compromised | verified |
| request_injective_agreement | Each executed operation was sent by the authenticated controller, and is executed once | verified |

Total proving time is about 12–15 s on a laptop.

**Mutation check.** `ODC_Handshake_NoOfferBinding.spthy` leaves the offer list out of the signed transcript. Tamarin finds a 10-step downgrade attack on it, which shows that `no_downgrade` is not vacuous.

## Figures (`figures/`)

These graphs were exported from Tamarin's interactive mode.

- `executable_honest_run.png`: a witness for the `executable` lemma. It shows an honest run of registration, the handshake, one request and its execution.
- `nobinding_offer_tampering.png`: the same honest-run witness on the variant without offer binding. The adversary replaces the second element of the offer (`o2`), and both sides still accept, so the tampering goes undetected.
- `nobinding_downgrade_attack.png`: the counterexample to `no_downgrade`. A hybrid-capable device is driven to the classical mode, and the controller accepts it.

## Reproduce

On Linux, or on Windows 11 under WSL (Ubuntu):

```
bash install_tamarin_wsl.sh   # one-time: installs Tamarin 1.10.0 + Maude 3.5
bash run_proofs.sh            # proves all lemmas and runs the mutation check
```

To explore the proofs graphically, run `tamarin-prover interactive .` and open http://127.0.0.1:3001.

## Scope

This is a symbolic model of the protocol *design*. It does not model vendor firmware or an implementation. It covers two algorithm modes. The four migration states and key-lifecycle transitions are planned extensions.
