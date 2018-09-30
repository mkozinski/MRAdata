if [ ! -d data ]; then
  echo "creating the dataset"
  OUT_DIR="orig_data"
  if [ ! -d "${OUT_DIR}" ]; then
    echo "downloading and unpacking the dataset"
    DN='ITKTubeTK - Bullitt - Healthy MR Database'
    if [ ! -d "${DN}" ]; then
      DNAME="download"
      if [ ! -d "${DNAME}" ]; then
        wget https://data.kitware.com/api/v1/collection/591086ee8d777f16d01e0724/download
      else
        echo "found an existing \"${DNAME}\" directory, I will not download the data again"
      fi
      unzip "${DNAME}"
      rm "${DNAME}"
    else
      echo "found an existing \"${DN}\" directory, I shall not download and unpack the data again"
    fi
    
    OUT_LBLDIR="${OUT_DIR}/lbl"
    OUT_IMGDIR="${OUT_DIR}/img"
    mkdir $OUT_DIR
    mkdir $OUT_LBLDIR
    mkdir $OUT_IMGDIR
    
    DNAME="${DN}/Designed Database of MR Brain Images of Healthy Volunteers"
    LBL_SUBDIR="AuxillaryData/VascularNetwork.tre"
    for D in "${DNAME}"/Normal*
    do
      ID=`echo $D | sed -e "s/.*\/Normal-\(\d\)*/\1/"`
      #echo ${ID}
      if [ -e "${D}/${LBL_SUBDIR}" ]; then
        cp "${D}/MRA/Normal${ID}-MRA.mha" "${OUT_IMGDIR}/${ID}.mha"
        cp "${D}/${LBL_SUBDIR}" "${OUT_LBLDIR}/${ID}.tre"
      fi
    done
    rm -rf "$DNAME"
    rm -rf "$DN"
  else
    echo "found an existing \"$OUT_DIR\" directory, I shall not acquire the dataset again"
  fi
  
  if [ ! -d lua_img ]; then
    echo "generating the inputs"
    python "convertMha2Py.py"
    th -e "dofile \"convertPy2Lua.lua\""
    rm -rf npy_img
  else
    echo "found an existing \"lua_img\" directory, not re-generating the inputs"
  fi
  
  if [ ! -d lbl ]; then
    echo "rendering the ground truths"
    th -e "dofile \"renderGT.lua\""
  else
    echo "I found an existing \"lbl\" dir, I will not re-render the ground truths"
  fi

  mkdir data
  mv lbl data
  mv lbl_MIP data
  mv lua_img data/img
  
  th -e "dofile \"cropData.lua\""
  th -e "dofile \"cut_data.lua\""
  th -e "dofile \"splitData.lua\""
  
else
  echo "found the \"data\" directory, not re-generating the data"
fi
