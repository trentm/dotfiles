. $HOME/.bashrc


if [[ -d $HOME/opt/google-cloud-sdc ]]; then
    # At least 'gcloud auth login' fails with SSL cert verification
    # issue if using ActivePython 2.7.1. Wow that's bad.
    export CLOUDSDK_PYTHON=/usr/bin/python

    # The next line updates PATH for the Google Cloud SDK.
    source '/Users/trentm/opt/google-cloud-sdk/path.bash.inc'

    # The next line enables bash completion for gcloud.
    source '/Users/trentm/opt/google-cloud-sdk/completion.bash.inc'

    # Setting PATH for Python 3.4
    # The orginal version is saved in .bash_profile.pysave
    PATH="/Library/Frameworks/Python.framework/Versions/3.4/bin:${PATH}"
    export PATH
fi

# Setting PATH for Python 3.5
# The orginal version is saved in .bash_profile.pysave
PATH="/Library/Frameworks/Python.framework/Versions/3.5/bin:${PATH}"
export PATH
