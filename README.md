# QuipperTest

I just used one third-party framework, and I have created the Cartfile. So you can run command "carthage update" to install it.

I divided two folders to organize the code, one is for video list and another is for video player.

I added some comments in code and I think it's ok

Basically, I used mvvm in this demo and I also used POP in some codes(Client and Request file).

I think landscape is best for watching video, so I force to landscape in video view.

In the video player view, I added some ux/ui:
1. You can tap view to hide/show controls
2. You can double tap to pause/play video
3. You can swipe up and down to adjust brightness in left half of screen
4. You can swipe up and down to adjust volume in right half of screen

I also added a couple of transition when you present or dismiss video player view.
There are a lot of way that can force landscape, but I took a more custom way.
