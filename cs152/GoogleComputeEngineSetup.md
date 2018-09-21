# Running on Google Compute Platform

## One-time



### Use Google Cloud Shell to get an instance created and running

We want to be using the Google Cloud command-line interface in order to create our instances, and to ssh into our instance once it's running.  One way to do this is to install the Google Cloud SDK onto your local machine, and then run from there (see later instructions: "Get Google Cloud SDK Installed on your local machine (optional)").

A simpler approach is to use Google Cloud Shell which provides a virtual machine and a persistent home directory (so you can do vim or bash customizations and they'll be maintained across Cloud shell invocations). One other thing Google Cloud Shell provides is tmux integration (this means that your session is retained across sessions, including any running programs).

#### Create Instance

1. Go to [Google Cloud Console](https://console.cloud.google.com).

2. Run Google Cloud Shell. Either follow this LINK, or click on the icon at the top-left of the screen (icon looks like a command line):
![alt Picture of toolbar](images/toolbar.png "Picture of toolbar")

3. Set your default zone in which to create instances:
```
gcloud config set compute/zone us-west1-b
```

4. Add a firewall rule (this will allow incoming connections to your jupyter server):
```
gcloud compute firewall-rules create default-allow-jupyter \
--allow tcp:8888-8889 \
--target-tags=jupyter
```

5. Create a GCE instance named *cs152* (once complete, this instance *will be running*. Make sure to stop it once you are done):
```
gcloud compute instances create cs152 \
--accelerator=count=1,type=nvidia-tesla-k80 \
--boot-disk-size=30GB \
--image-family ubuntu-1604-lts \
--image-project ubuntu-os-cloud \
--machine-type=n1-standard-4 \
--preemptible \
--tags=jupyter 
```

   If you want (and are willing to pay for) an SSD, add the following option to the previous command:```
    --boot-disk-type=pd-ssd
    ```
	

#### Install Software on instance
Now, it's time to start installing/configuring software.

1. Open an ssh window to your new instance.
```
gcloud compute ssh cs152 
```
You may see some warnings.  You'll be prompted for a passphrase for your SSH private key.  You can leave it empty.

2. Pull in our repository that contains our scripts (along with our notebooks, and so on). (Executed  on our cs152 GCE instance).
```
  git clone https://github.com/nrhodes/cs152.git 
```

3. Run our script (executed  on our cs152 GCE instance):
```
cs152/bin/GoogleComputeEngineSetup.sh
```

4. Logout of your GCE instance/SSH session:
```
exit
```

5. At this point, your machine should be all set up.  Stop your instance (so that we can reboot with the new  GPU drivers).
```
gcloud compute instances stop cs152
```


## On-going commands


### Starting your instance

1. Start the instance:
```
gcloud compute instances start cs152
```

2. Check the instance's IP address:
```
gcloud compute instances list
```
The command will output something of the form:
```
NAME    ZONE        MACHINE_TYPE   PREEMPTIBLE  INTERNAL_IP  EXTERNAL_IP    STATUS
cs152  us-west1-b  n1-standard-4  true         10.138.0.7   35.230.49.129  RUNNING
```
You are interested in the EXTERNAL\_IP address (last column from the right). Copy that IP address; you'll need it later.

3. Once your instance is running, you can ssh into it. Note that we are setting up ssh forwarding so that any references to port 8888 on our local host will be redirected to port 8888 on our GCE instance (which will be running our Jupyter server).

```
gcloud compute ssh cs152
```

4. Run jupyter lab (from your SSH window):
```
jupyter lab
```

5. You'll see a line in the jupyter lab output that looks like:
```Copy/paste this URL into your bowser when you connect for the first time, 
   to login with a token:
     http://(cs152 or 127.0.0.1):8888/?token=b085b4e2e8065317e317320533a97193535f64f063f22bba
```

Copy the link, paste it into your browser, and change the hostname (between ```//``` and ```:8888``` to the IP address you saved earlier). That should connect to your Jupyter server.   If you want to pay extra (approximately 25 cents/day), you can create a static IP address for your instance.  That way, you can just bookmark the Jupyter URL and not have to re-figure out the IP address each time. 


When you are ready to kill jupyter lab, type ctrl-C, and then respond Y to the prompt.


### Stopping your instance
```
gcloud compute instances stop cs152
```

### Checking what's running
```
gcloud compute instances list
```

### Delete an instance
```
gcloud compute instances delete cs152
```


### Get Google Cloud SDK Installed on your local machine (optional)


1. Install [Google Cloud SDK](https://cloud.google.com/sdk/install) on your local machine. (For Mac OS and Windows, you'll want to use the interactive installer at [https://cloud.google.com/sdk/docs/downloads-interactive]).  Run only steps 1 and steps 2 (_don't *run step 3 ```gcloud init``` yet_). For steps 1 and 2, you can answer any questions with default (just hit Enter).

2. Go to the [GCP Console](https://console.cloud.google.com) 

3. Create a Service account

    1. On the left bar, go to IAM & admin -> Service accounts
    2. Add a Service Account name
    3. Specify project role as owner [project -> owner]
    4. Select “furnish a new private key”
    5. Select type as JSON.
	
	   A json file will be downloaded. Save file locally and find the path to json file
       
3. Now it's time to authenticate:
```gcloud auth activate-service-account [client_email] --key-file=[json_file_path]```
  
    where client\_email is in the json file (look for the ```client_email`` field in the json file) downloaded and json\_file\_path is the path to the json file
		
4. Now, you can run ```gcloud init``` from your local terminal window
    1. Use defaults except:
		 * when prompted *API [cloudresourcemanager.googleapis.com] not enabled on project. Would you like to anable and retry (this wkll take a few minutes)?*, answer ```Y```
	     * when asked  *Which Google Compute Engine zone would you like to use as project default?*, answer ```[11] us-west1-b```.

Once you've done this setup, you can choose to use gcloud from your local machine rather than running it from Google Cloud Shell.


### Setting up static IP address (OPTIONAL)

These are an outline of steps, not complete steps.

1. Setup a static IP address to connect to:
```
gcloud compute addresses create test-static --region us-west1

2. Set a shell variable to the newly-allocated static IP address:
```
IP=`gcloud compute addresses list | awk '/test-static/{print $3}'`
echo $IP
```

3. When you create your instance, add the flag:
```
--address=$IP
```
