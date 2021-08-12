#!/bin/csh

bsub -I vcs -lca -sverilog -full64 -kdb -f svfile.f -debug_access+all -l vcs.log -cm_dir cov
#bsub -I ./simv -l simv.log +ntb_random_seed=1

DC=$(date +%F%H%M%S)
COV_OPTIONS="-covg_no_override_test -cm_dir cov -cm_name test_$DC"
bsub -I ./simv +ntb_random_seed_automatic -l simv.log $COV_OPTIONS

verdi.lsf -ssf my.fsdb &

verdi.lsf -cov -covdir cov.vdb
