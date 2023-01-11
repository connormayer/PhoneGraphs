name="English_RCC_COV_onset_types_no_tails"
config="confs/English_RCC_onsets_cov.config"
premade_classes=""
cluster_on="contexts"
input_path="../example/Data/onset_types_arpa.txt"
experiment_dir="../example/"
test_file="../example/Data/Daland_et_al_arpa_onsets.txt"

PhoneGraphs="../src" 

echo "0. Making output directories and phone file"

### Make output folders if needed ###
if [[ ! -e ${experiment_dir}/Communities/ ]]; then
    mkdir ${experiment_dir}/Communities/
fi

if [[ ! -e ${experiment_dir}/Grammars/ ]]; then
    mkdir ${experiment_dir}/Grammars/
fi

if [[ ! -e ${experiment_dir}/Judgements/ ]]; then
    mkdir ${experiment_dir}/Judgements/
fi

python3 ${PhoneGraphs}/make_phones.py ${input_path} > ${experiment_dir}/${name}_phones.txt #make phones file

for i in {1..1}

    do

    ### Run class discovery ###
    if [ -z "${premade_classes}" ]; then
        echo "1. Running class discovery algorithm on ${cluster_on}"
        if [ ${cluster_on} == "phones" ]; then
            python3 ${PhoneGraphs}/phoneme_clustering.py ${input_path} ${experiment_dir}/Communities/${name}_${i} ${config}
        else
            python3 ${PhoneGraphs}/context_clustering.py ${input_path} ${experiment_dir}/Communities/${name}_${i} ${config}
        fi
    else
        echo "1. Skipping class discovery, using classes in ${premade_classes}"
        cp ${premade_classes} ${experiment_dir}/Communities/${name}
    fi
        
    ### Fit a MaxEnt model ###

    echo "2. Fitting phonotactic grammar"

    python3 ${PhoneGraphs}/ng_phonotactic.py ${input_path} ${experiment_dir}/Communities/${name}_${i} ${test_file} ${experiment_dir}/${name}_phones.txt ${experiment_dir} ${name}_${i} ${config}



    echo "3. Testing Daland Et Al correlations"

    python3 ${experiment_dir}/Scripts/daland_eval.py ${experiment_dir}/Judgements/${name}_${i} ${experiment_dir}/Scripts/Daland_etal_2011__AverageScores.csv 



    done
