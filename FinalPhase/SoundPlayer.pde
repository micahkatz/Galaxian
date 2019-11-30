
import ddf.minim.*; // Import Sound Library

class SoundPlayer {
  Minim minimplay;
  AudioSample boomPlayer, popPlayer;
  AudioPlayer gameOverPlayer, bgMusicPlayer;

  SoundPlayer(Object app) {
    minimplay = new Minim(app); 
    boomPlayer = minimplay.loadSample("Explosion.wav", 1024); 
    popPlayer = minimplay.loadSample("Laser.wav", 1024);
    gameOverPlayer = minimplay.loadFile("GameOver2.wav");
    bgMusicPlayer = minimplay.loadFile("Galaga_Song.wav");
  }

  void playExplosion() {
    boomPlayer.trigger();
  }

  void playPop() {
    popPlayer.trigger();
  }
  
  void playGameOver() {
    if(!gameOverPlayer.isPlaying()){
    
      gameOverPlayer.pause();
      
      gameOverPlayer.rewind();
      
      gameOverPlayer.play();
      
    }
  }
  
  void playBgMusic() {
    if(!bgMusicPlayer.isPlaying()){
    
      bgMusicPlayer.pause();
      
      bgMusicPlayer.rewind();
      
      bgMusicPlayer.play();
      
    }
    
  }
  
  void stopBgMusic() {
    if(bgMusicPlayer.isPlaying()){
    
      bgMusicPlayer.pause();
      
    }
    
  }
  
}
