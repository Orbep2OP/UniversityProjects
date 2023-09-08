package graphics;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.Scanner;

public class GameEngineMain {

    public static void main(String[] args) {
        // TODO Auto-generated method stub
        GameEngine.getInstance().start();
    }

    public static void showPlayer(Player p) {
        String s = p.getPlayerName();
        int i = p.getPoints();
        System.out.println("Your name: " + s + " - "  + "Your Points: " + i);
    }

    public static void showTop5List() {
        System.out.println("These are the top 5 players: " + "\n");
        int i = 0;
        File file = new File("RogueGame/Top_5_Players.txt");
        try {
            Scanner scan = new Scanner(file);

            while(scan.hasNextLine()) {
                String s = scan.nextLine();
                i++;
                System.out.println(i + ". " + s + "\n");
            }
            scan.close();
        }
        catch(FileNotFoundException e) {
            System.err.println("O ficheiro Top_5_Players.txt não existe");
        }
        System.exit(0);
    }



}
