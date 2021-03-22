#!/bin/bash
echo "starting learning"

# the setup here is the following:
# in gmc_net/src/cluster_experiments/e_*.py are python scripts that start experiments, e.g. trainings with different meta parameters.
# these do not care which gpu they are started on. this script has a list of nodes and gpus (format node_gpus, that you have to book
# in our google sheet), and a list of experiments. It then starts all experiments as long as it doesn't run out of GPUs. The python 
# output is written to ~/data/logs (files are overwritten, so you'll only have the last run of that experiment).

# you can either select the GPU by setting the environment variable (CUDA_VISIBLE_DEVICES=$gpu), or handing it as a parameter to the
# python script (cuda:$gpu). You have to implement the logic in the latter case.

# starting python in unbuffered mode (-u) in order to be able to monitor the logfile
# -m starts the script as a module, which is necessary in some cases (project consists of several parallel modules that include each other).

mkdir -p ~/data/logs
mkdir -p ~/data/weights

experiment_list=({0..7})
# experiment_list=(0 2 4 5 10 11)
# experiment_list=(0 1 2 3)
# experiment_list=(1 2)
nodes="dl2_0123 dl3_0123"
experiment_index=0

for dl in $nodes; do
    echo -e "\e[7m\e[93m===${dl}===\e[27m\e[39m"
    dl_host=$(echo $dl | cut -d'_' -f 1)
    gpus=$(echo $dl | cut -d'_' -f 2)
    for (( i=0; i<${#gpus}; i++ )); do
        gpu=${gpus:$i:1}
        experiment=${experiment_list[$experiment_index]}
        echo "starting experiment $experiment on $dl_host on gpu $gpu"
        ssh $dl_host "mkdir -p /scratch/username/project"
#         ssh $dl_host "tmux new -d \"module load cuda/11.2; module load gcc/7.5.0; cd ~/gmc_net/src; CUDA_VISIBLE_DEVICES=$gpu python -uO -m cluster_experiments.e_$experiment cuda |& tee ~/data/logs/cluster_experiments.e_$experiment.log\""
#        ssh $dl_host "tmux new -d \"module load cuda/10.2; module load gcc/7.5.0; cd ~/gmc_net/src; CUDA_VISIBLE_DEVICES=$gpu python -uO -m cluster_experiments.e_$experiment cuda |& tee ~/data/logs/cluster_experiments.e_$experiment.log\""
        experiment_index=$((experiment_index + 1))
        if [ $experiment_index -ge ${#experiment_list[@]} ]; then
            echo "all experiments started"
            exit 0
        fi
    done
done
echo "not everything started, ran out of nodes"
