# LUMIP_reconstruction
python scripts for reconstructing land use change impact on surface temperature over the past millennium


#module load conda
#source activate iacpy3_2020

#interactive mode:
#jupyter notebook --browser=chromium &

#batch script:
#python script.py

#check CF compliance of IO files:
#cfchecks file.nc

##to run jupiter remotely:

#On the server

#tmux new-session -s 'background jobs'
#alternative "screen"
#cd ~
#module load conda/<year>
#source activate <environment>
#jupyter notebook --no-browser --port 55000

#If the port is already in use jupyter will select the next higher available. Make sure that you use the right port in the next part.
#On your computer:

#ssh -f -N -L localhost:8888:localhost:55000 SERVER

#Open the browser and go to: http://127.0.0.1:8888
#Copy the token given by the jupyter notebook on the server and paste it in the login field.
    