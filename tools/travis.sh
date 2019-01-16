set -x
ulimit -n 4096

echo "TRAVIS_EVENT_TYPE value $TRAVIS_EVENT_TYPE"

if [ $TRAVIS_EVENT_TYPE = cron ] || [ $TRAVIS_EVENT_TYPE = api ]; then
    sudo pwsh -NoProfile -NonInteractive -c "Import-Module ./tools/Travis.psm1;
                  Invoke-InstallDependencies;
                  Invoke-UnitTests;"
else
    sudo pwsh -NoProfile -NonInteractive -c "Import-Module ./tools/Travis.psm1;
                  Invoke-InstallDependencies;
                  Invoke-UnitTests;"
fi
