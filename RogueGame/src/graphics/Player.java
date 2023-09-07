package graphics;

public class Player {

    private String PlayerName;
    private int points;
    private boolean wonGame;

    public Player(String s, int points) {
        this.PlayerName = s;
        this.points = points;
        wonGame = false;
    }

    public Player(String s) {
        this.PlayerName = s;
        this.points = 0;
        wonGame = false;
    }

    public void wonGame() {
        wonGame = true;
    }

    public void updatePoints(int p) {
        this.points = this.points + p;
    }

    public int getPoints() {
        return points;
    }

    public String getPlayerName() {
        return PlayerName;
    }

    public void setPoints(int i) {
        this.points = this.points + i;
    }

    @Override
    public String toString() {
        if(wonGame) {
            return "Player: "+ PlayerName + " - " + "Points: " + points + " - " + "Won the game";
        }
        return "Player: "+ PlayerName + " - " + "Points: " + points + " - " + "Didn't win the game";
    }

    public boolean samePlayer(Player p) {
        if(p.getPlayerName().equals(this.PlayerName) && p.getPoints() == this.points) {
            return true;
        }
        return false;
    }

}
