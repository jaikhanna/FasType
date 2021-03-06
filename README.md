# FasType
How fast and accurately can you type?

##How to install
The app is not available on the AppStore yet, but you can download the code and run it on your iOS device.

Note that although this app runs on all iOS devices on iOS 9.0 or greater, we prefer you run it on an iPhone 6/6s/6 Plus/ 6s Plus for the best experience.

#####Steps:

1. Download the source onto your Mac.
2. Open the downloaded folder and open the file named <b>FasType.xcworkspace</b>. This should open up Xcode and you should now be able to see the project classes and folders.
3. In the Project Navigator on the left column, click on the highest directory folder named <b>FasType.xcodeproj</b/> and this should open the project settings.
4. At this point, you might want to change the <b>Bundle Identifier</b> to a unique text to be able to run the app from your Mac. We suggest you change it to <b>com.XXXX.FasType</b> where <b>XXXX</b> comes from your email address - XXXX@someDomain.com.
5. You might also want to click on the <b>Team</b> dropdown and then <b>Add an Account...</b>. This will require you to enter your Apple Id and password (The app does <b>not</b> store your credentials at any point).
6. Open Terminal and cd into the downloaded project folder. 
7. Type <b>gem which cocoapods</b> - This should tell you if you have cocoapods installed or not. If not then run <b>sudo gem install cocoapods</b>.
8. Run <b>pod install</b> and wait till the command finishes running.
9. Now, you can connect your device and run the app by clicking on the play/build & run button in Xcode.
10. This might give you an error saying that the developer profile is not trusted. To fix this, go to your device Settings ->General->Device Management->Your Apple ID->Trust "Your Apple ID"->Trust.
11. You can now go back to Xcode and run the app again. 
12. The final step - <b>Enjoy!</b>

##Issues?
If you face any issues at any point, you can contact us at <jkhanna@usc.edu> or <pranshuk@usc.edu> and we'll help you to the best we can.

##License

###1
Copyright (C) 2015 - 2016, Daniel Dahan and CosmicMind, Inc. http://cosmicmind.io. All rights reserved.

1. Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

2. Redistributions of source code must retain the above copyright notice, this
list of conditions and the following disclaimer.

3. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

Neither the name of Material nor the names of its contributors may be used to endorse or promote products derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

###2
Copyright (c) 2014-2015 Meng To (meng@designcode.io)

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
