#! /bin/bash
sudo apt-get install libpq-dev python-dev -y
sudo apt-get install python3-venv -y
cd /home/ubuntu/
touch export.sh
sudo chmod 775 export.sh
echo export access_key=${a_key} >> export.sh
echo export secret_key=${s_key} >> export.sh
echo export endpoint=${endpoint} >> export.sh
echo export db_name=${db_name} >> export.sh
echo export db_user=${db_user} >> export.sh
echo export db_pass=${db_pass} >> export.sh
echo export bucket=${bucket} >> export.sh
touch export.env
sudo chmod 775 export.env
echo access_key=${a_key} >> export.env
echo secret_key=${s_key} >> export.env
echo endpoint=${endpoint} >> export.env
echo db_name=${db_name} >> export.env
echo db_user=${db_user} >> export.env
echo db_pass=${db_pass} >> export.env
echo bucket=${bucket} >> export.env
