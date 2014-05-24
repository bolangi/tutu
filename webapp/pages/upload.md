<form action="/upload-file" method="post" enctype="multipart/form-data">
<h2>Welcome to the $WEBSITE_NAME Uploading Service!</h2>
<p>Legal content only! 
<p><b>Upload area (optional) </b><br>
<p>
<INPUT TYPE=RADIO NAME="category" VALUE="audio">audio<BR>
<INPUT TYPE=RADIO NAME="category" VALUE="video">video<BR>
<INPUT TYPE=RADIO NAME="category" VALUE="transcripts">transcripts<BR>
<INPUT TYPE=RADIO NAME="category" VALUE="presentations">presentations<BR>
<INPUT TYPE=RADIO NAME="category" VALUE="misc">misc<BR>
 
<p><b>File to upload: </b><input type="file" name="filename" /></p>
<p><b>File description (ignored) </b><input type="text" name="description" size=60 maxlength=60/></p>
<p><b><input type="submit" name="Upload" value="Start Upload!!" /></p>
</form>

<h2><a href="/how-to-upload">What is this?</a></h2>
