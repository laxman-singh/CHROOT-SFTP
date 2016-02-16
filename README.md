# CHROOT-SFTP
Shell scripts for managing (i.e. create/delete) SFTP users in CHROOT JAIL Environment.

Script successfully tested on Fedora 23, RedHat Enterprise Linux 6.x.


<h2>SFTP Configuration: </h2>

<b>Dependencies:</b> OpenSSH <br/>
<b>Configuration: </b> <br/>

<ul>
  <li>Edit /etc/ssh/sshd_config <br/> <code><i># sudo vim /etc/ssh/sshd_config</i></code></li>
  <li>Comment existing Subsystem: <br/> <code><i># Subsystem sftp /usr/lib/openssh/sftp-server</i></code></li>
  <li>Add at end of sshd_config file, add the following lines: <br/> <i><code>Subsystem	sftp	internal-sftp </code> <br/>
  <code>Match Group sftpusers </code> <br/>
	<code>&emsp;&ensp;ChrootDirectory /opt/sftp/%u </code> <br/>
	<code>&emsp;&ensp;ForceCommand internal-sftp </code> <br/>
	<code>&emsp;&ensp;X11Forwarding no </code> <br/>
	<code>&emsp;&ensp;AllowTcpForwarding no </code> <br/>
</i></li>
</ul>

<ul>
  <li> Create SFTP CHROOT Directory and add SFTP Group : <br/>
  <i><code> # mkdir /opt/sftp/ </code> <br/>
    <code> # groupadd sftpusers </code>
  </li>
</ul>
