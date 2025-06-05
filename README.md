# Fortress-assessment
Docker/Kubernetes Assessment for Senior SRE role at Fortress

This project implements a basic FTP server running in passive mode, deployed into a Kubernetes cluster via Docker Desktop on macOS. It was developed as part of an interview assignment.

## Features

- FTP server using `bftpd` (not vsftpd or proftpd)
- Passive mode configuration on TCP port 2121
- Kubernetes manifests for deployment
- User login: `admin` / `admin`
- Persistent storage via PVC

## Introduction

Thank you for this opportunity. I'm excited about the potential to connect further and continue the interview process.

A few notes about me and my experience:  
I haven't worked with Kubernetes before, so this project was a great learning experience. It's also been over a decade since I last built or managed an FTP server, so I had to brush off some rust and dig through the archives a bit.

I know the configuration isn't fully optimized — I ran into some limitations in my local build environment. I relied heavily on Google and ChatGPT to help navigate the Kubernetes side of things, especially since this was my first time deploying containers to a cluster. As such, I'm not fully confident this follows best practices, but I did my best given the constraints.

Running everything locally on my Mac introduced some unique challenges, but I was able to work around them and get the full setup running.

This deployment includes a few assumptions:
- This will be the only container using ports `2121` and `30000–30009`. I apologize if this causes any conflicts. With the requirement to support passive FTP on port `2121`, this was the best method I could implement and test in my environment.
- The server has not been fully hardened. I did only a light review of `bftpd`, so I can’t guarantee its security posture. However, I took steps during the build process to minimize artifacts and ensure a small deployment footprint.

Again, thank you for the opportunity — I look forward to hearing from you soon.

## Setup

For this setup, I used a MacBook Pro running Docker Desktop. I configured a single-node Kubernetes cluster to handle the deployment.

Due to limitations with Docker Desktop, I initially tested the configuration using `NodePort`. During early testing, I connected to the FTP server via port `32121`. Once I had verified functionality, I updated the configuration to force connections through port `2121`.

To allow connections on my Mac for both control and passive data ports, I set up port forwarding:

```bash
kubectl port-forward svc/ftp-service 2121 30000 30001 30002 30003 30004 30005 30006 30007 30008 30009 &
```

This allowed me to re-test after the configuration changes. I was still able to connect to the FTP server and upload files successfully.

I’ve included two text files in the repository — before.txt and after.txt — to demonstrate file persistence. I used the following command before and after redeploying the pod to show that the same files remained present:

```
kubectl exec {$POD_ID} -- ls /srv/ftp > {$FILENAME}
```

Once testing was complete, I cleaned up the environment and pushed all final changes to GitHub.

## Notes & Potential Issues

Since I'm not sure of your exact environment, here are a few notes on configuration details that may need to be adjusted.

In the `bftpd.conf` file, I had to set the following line:

```conf
OVERRIDE_IP="127.0.0.1"
```

This was necessary due to how Docker Desktop on macOS handles networking for passive FTP. When the client initially connects to port 2121 (or 32121 during early testing), the FTP server attempts to redirect the client to the container’s internal IP address — which is not routable from the host. I couldn’t find a clean way to make this work natively on macOS, so setting OVERRIDE_IP forced the passive connection to use 127.0.0.1 instead of the internal container IP.

However, this setting may cause issues on a standard multi-node Kubernetes cluster or in cloud deployments. If you encounter connection problems, you may need to update or remove this setting depending on your network topology.

Another note: this override setting causes the container to fail startup when run directly with Docker on my Mac. Initially, I set it to my laptop’s local IP for standalone testing, but that didn’t work with Kubernetes. Switching to a loopback address resolved the issue in the cluster, so I left it that way.

If the static port mappings (2121 and 30000–30009) cause conflicts, they can be safely adjusted in the dockerfile, service, and deployment files. Let me know if you'd like me to update those for your environment.

Worst case, I’d be happy to jump on a quick screen share to walk through the setup and help troubleshoot any issues you run into.

