#  WatchDataLogger01

#  Known issues

1. Sensor DAQ with "motion" stops in approximately 10 minutes, or in suspended mode of the App. In order to do long-term contineous measurement, select "motion and heart rate".
2. DateTimeMilisec value in motion data csv can be erroneously repeated. As the timestamp from CMDeviceMotion is correct, this might be an issue due to Date() and/or file access.

#  References

References on file transfer
[1] https://developer.apple.com/documentation/watchconnectivity/using_watch_connectivity_to_communicate_between_your_apple_watch_app_and_iphone_app

References on motion data acquisition
[1] https://developer.apple.com/documentation/coremotion

References on workout session and heart rate data acquision
[1] https://developer.apple.com/documentation/healthkit/workouts_and_activity_rings/speedysloth_creating_a_workout
