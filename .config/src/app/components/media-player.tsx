import { useState } from 'react';
import { Play, Pause, SkipBack, SkipForward, Volume2 } from 'lucide-react';
import { Slider } from './ui/slider';

export function MediaPlayer() {
  const [isPlaying, setIsPlaying] = useState(false);
  const [volume, setVolume] = useState([70]);
  const [progress, setProgress] = useState([35]);

  const togglePlay = () => {
    setIsPlaying(!isPlaying);
  };

  return (
    <div className="w-80 bg-zinc-900 rounded-lg shadow-2xl border border-zinc-800 overflow-hidden">
      {/* Album Art */}
      <div className="relative aspect-square w-full">
        <img 
          src="https://images.unsplash.com/photo-1644855640845-ab57a047320e?crop=entropy&cs=tinysrgb&fit=max&fm=jpg&ixid=M3w3Nzg4Nzd8MHwxfHNlYXJjaHwxfHxhbGJ1bSUyMGNvdmVyJTIwbXVzaWN8ZW58MXx8fHwxNzY3OTk0NjcxfDA&ixlib=rb-4.1.0&q=80&w=1080&utm_source=figma&utm_medium=referral"
          alt="Album Art"
          className="w-full h-full object-cover"
        />
      </div>

      {/* Player Controls */}
      <div className="p-4 space-y-3">
        {/* Track Info */}
        <div className="space-y-0.5">
          <h3 className="text-white text-sm font-medium truncate">Midnight Dreams</h3>
          <p className="text-zinc-400 text-xs truncate">The Wanderers</p>
        </div>

        {/* Progress Bar */}
        <div className="space-y-1">
          <Slider 
            value={progress} 
            onValueChange={setProgress}
            max={100} 
            step={1}
            className="w-full"
          />
          <div className="flex justify-between text-[10px] text-zinc-500">
            <span>1:24</span>
            <span>3:48</span>
          </div>
        </div>

        {/* Control Buttons */}
        <div className="flex items-center justify-center gap-3">
          <button 
            className="text-zinc-400 hover:text-white transition-colors p-1.5"
            aria-label="Previous"
          >
            <SkipBack className="w-5 h-5" />
          </button>
          
          <button 
            onClick={togglePlay}
            className="bg-white text-zinc-900 rounded-full p-2.5 hover:bg-zinc-200 transition-colors"
            aria-label={isPlaying ? "Pause" : "Play"}
          >
            {isPlaying ? (
              <Pause className="w-5 h-5 fill-current" />
            ) : (
              <Play className="w-5 h-5 fill-current ml-0.5" />
            )}
          </button>

          <button 
            className="text-zinc-400 hover:text-white transition-colors p-1.5"
            aria-label="Next"
          >
            <SkipForward className="w-5 h-5" />
          </button>
        </div>

        {/* Volume Control */}
        <div className="flex items-center gap-2">
          <Volume2 className="w-4 h-4 text-zinc-400" />
          <Slider 
            value={volume} 
            onValueChange={setVolume}
            max={100} 
            step={1}
            className="flex-1"
          />
          <span className="text-xs text-zinc-500 w-8 text-right">{volume}%</span>
        </div>
      </div>
    </div>
  );
}
