# Luxometer

Luxometer is a Swift library that uses iPhone camera to measure ambient light illuminance in lux.

## Installation

Use the Swift Package Manager to install Luxometer: 

1. In Xcode go to File ‣ Add Packages
2. Enter https://github.com/Basistiy/Luxometer in the search field.


## Usage

Luxometer uses iPhone cameras so you need to add "Privacy - Camera Usage Description" description to the Info.plist file of your project.

import Luxometer

let luxometer = Luxometer()

luxometer.capturedIlluminance = {value in

 //The value is equal to ambient light illuminance in lux. The value is output 30 times a second. 
 
}

## Camera change

luxometer.changeCamera()


## Calibration

The output lux value is calibrated for iPhone 12 mini front camera by default. Calibration for other devices is required.
Change luxometer.calibrationConstant to adjust output illuminance value.


## Contributing

Pull requests are welcome. 


## License

[MIT](https://choosealicense.com/licenses/mit/)
