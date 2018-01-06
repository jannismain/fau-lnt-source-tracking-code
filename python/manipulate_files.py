import os
import sys
import glob
os.chdir("matlab/mainczjs/evaluation/results/T60/")
# rename_dict = {"_5em":"_em=5_", 
#                "0snr":"SNR=0",
#                "0.0T60":"T60=0.0",
#                "0.5m":"md=0.5"}
FILES = glob.glob("*results.txt")
for f in FILES:
    f_old = f
    if f.find("refl-ord")<0:
        f_before = f
        f = f.replace("_results", "_refl-ord=3_results")
        f = f.replace("_baseresults", "_refl-ord=3_results")
    if f.find("wd=")<0:
        f_before = f
        f = f.replace("md=0.5", "md=0.5_wd=1.2")
    print("OLD: ", f_old,)
    print("NEW: ", f,)
    os.renames(f_old, f)
