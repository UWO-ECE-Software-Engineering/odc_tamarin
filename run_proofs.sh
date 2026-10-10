#!/usr/bin/env bash
# Proves all lemmas of the ODC model and checks that the broken variant is caught.
# Run from the folder that holds the .spthy files:  bash run_proofs.sh
set -uo pipefail
export LANG=C.UTF-8 LC_ALL=C.UTF-8

echo "== ODC_Handshake.spthy (all lemmas should be 'verified') =="
tamarin-prover --prove ODC_Handshake.spthy > proof_output.txt 2>&1
sed -n '/summary of summaries/,$p' proof_output.txt

echo "== ODC_Handshake_NoOfferBinding.spthy (no_downgrade should be 'falsified') =="
tamarin-prover --prove=no_downgrade ODC_Handshake_NoOfferBinding.spthy > mutant_output.txt 2>&1
grep -E 'no_downgrade \(' mutant_output.txt
