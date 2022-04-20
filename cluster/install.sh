BASE_SCRIPT_SOURCE="https://raw.githubusercontent.com/mwildt/az-ops/main/cluster"

SCRIPTS=()

while [[ $# -gt 0 ]]; do
  case $1 in
    --baseScriptSource)
      BASE_SCRIPT_SOURCE="$2"
      shift # past argument
      shift # past value
      ;;
    --)
      CURRENT=$2
      SCRIPTS+=($CURRENT)
      shift # past argument
      shift # past value
      ;;
    -*|--*)
      echo "Unknown option $1"
      exit 1
      ;;
    *)
      echo "Unknown paramer $1"
      exit 1
      ;;
  esac
done

sudo mkdir -p /var/install

for script in "${SCRIPTS[@]}"
do
    echo "run $i"
    scriptfile="/var/install/$script"
    scriptSource="$BASE_SCRIPT_SOURCE/$script"
    echo "load script from source $scriptSource"
    sudo curl -o $scriptfile $scriptSource
    sudo cat $scriptfile
    sudo chmod +x $scriptfile
done


