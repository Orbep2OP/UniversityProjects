package graphics;

import java.io.File;
import java.io.FileNotFoundException;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.List;
import java.util.Scanner;

public class BestPlayers {

    private List<Player> top5 = new ArrayList<Player>();

    public BestPlayers() {
        File file = new File("C:\\Users\\themo\\OneDrive\\Documents\\GitHub\\UniversityProjects\\RogueGame\\Top_5_Players.txt");
        try {
            Scanner scan = new Scanner(file);

            while(scan.hasNextLine()) {
                String line = scan.nextLine();
                Player p = getPlayerFromLine(line);
                top5.add(p);
            }
            scan.close();
        }
        catch(FileNotFoundException e) {
            System.err.println("O ficheiro Top_5_Players.txt não existe");
        }
    }

    public Player getPlayerFromLine(String s) {
        String[] aux = s.split(" - ");
        String[] auxName = aux[0].split(":");
        String name = auxName[1].strip();
        String[] auxPoints = aux[1].split(":");
        int points = Integer.parseInt(auxPoints[1].strip());
        Player p = new Player(name, points);
        return p;
    }

    private int getLowestPoints() {
        int points = top5.get(0).getPoints();

        for(Player p: top5) {
            if(p.getPoints() < points) {
                points = p.getPoints();
            }
        }
        return points;
    }

    private Player getLowestPlayer() {
        int index = -1;
        for(Player p: top5) {
            index++;
            if(p.getPoints() == getLowestPoints()) {
                break;
            }
        }
        return top5.get(index);
    }

    private boolean isPlayerInTop5(Player p) {
        for(Player player: top5) {
            if(player.equals(p)) {
                return true;
            }
        }
        return false;
    }

    public void addPlayer(Player p) {

        if(top5.size() == 0) {
            top5.add(p);
            return;
        }

        if(top5.size() < 5) {
            if(isPlayerInTop5(p) == false) {
                top5.add(p);
                sortList();
                return;
            }
        }

        if(top5.size() == 5) {
            if(p.getPoints() > getLowestPlayer().getPoints()) {
                top5.removeIf(P -> P.equals(getLowestPlayer()));
                top5.add(p);
                sortList();
                return;
            }
        }
    }

    private void sortList() {
        top5.sort((p1, p2) -> p2.getPoints() - p1.getPoints());
    }

    public void sendToFile() {
        sortList();
        try {
            File file = new File("C:\\Users\\themo\\OneDrive\\Documents\\GitHub\\UniversityProjects\\RogueGame\\Top_5_Players.txt");
            PrintWriter writter = new PrintWriter(file);
            for(Player p: top5) {
                writter.println(p);
            }
            writter.close();
        }
        catch(FileNotFoundException e) {
            System.err.println("Ficheiro Top_5_Players.txt nao existe");
        }
    }

    public static void updateRankings(boolean wonTheGame) {
        BestPlayers ranks = new BestPlayers();
        String s2 = GameEngine.getInstance().getgui().askUser("If you want to get added to the leaderboards write YES");

        if(s2 != null) {
            if(s2.equals("YES")) {
                String s = GameEngine.getInstance().getgui().askUser("Please write you name");
                Player p = new Player(s, GameEngine.getInstance().getPoints());
                if(wonTheGame) {
                    p.updatePoints(100);
                    p.wonGame();
                }
                ranks.addPlayer(p);
                ranks.sendToFile();
                GameEngineMain.showPlayer(p);
                GameEngineMain.showTop5List();
            }
        }
        System.exit(0);
    }

}
