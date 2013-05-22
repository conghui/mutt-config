#!/usr/bin/python
import os
import sys
import subprocess
import email
import email.parser
import tempfile
from email.mime.multipart import MIMEMultipart
from email.mime.text import MIMEText
 
if len(sys.argv) == 1:
    print "usage: mark_and_send.py markdown_program [markdown_flag]"
    print "where:"
    print "    markdown_program is the name of the program to translate markdown."
    print "    markdown_flag is an optional indicator in the first line that determines whether to run the markdown program"
    sys.exit(0)
 
markdown_program = sys.argv[1]
 
p = email.parser.Parser()
m = p.parsestr(sys.stdin.read())
 
# is this a single header?
do_markdown = False
if not m.is_multipart() and m.get_content_maintype() == 'text' and m.get_content_subtype() == 'plain':
    do_markdown = True
    payload = m.get_payload()
    # optionally check the markdown flag
    if len(sys.argv) == 3:
        lines = payload.split("\n")
        do_markdown = lines[0] == sys.argv[2]
        if do_markdown:
            payload = "\n".join(lines[1:])
 
if do_markdown:
    tf = tempfile.NamedTemporaryFile(delete=False)
    tf.write(payload)
    tf.close()
 
    (markdown, error) = subprocess.Popen(markdown_program.split() + [tf.name], stdout=subprocess.PIPE).communicate()
 
    # create a new message with the exact same headers
    new_message = MIMEMultipart('alternative')
    for (k,v) in m._headers:
        new_message[k] = v
 
    text_plain = MIMEText(payload, 'plain')
    new_message.attach(text_plain)
 
    text_html = MIMEText(markdown, 'html')
    new_message.attach(text_html)
 
    print new_message.as_string()
    os.unlink(tf.name)
else:
    print m.as_string()
