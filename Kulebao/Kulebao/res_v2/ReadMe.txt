for files in `ls`; do mv $files v2-${files}; done

for files in `ls`; do rename .png @2x.png *; done