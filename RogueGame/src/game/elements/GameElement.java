package game.elements;

import java.util.List;

import graphics.GameEngine;
import gui.ImageTile;
import utils.Point2D;

public abstract class GameElement implements ImageTile{

    private int Layer;
    private Point2D position;
    private String name;

    public GameElement(Point2D p) {
        this.position = p;
    }

    public boolean equals(GameElement GE) {
        if(GE.getPosition().equals(this.position) && GE.getName().equals(this.name)) {
            return true;
        }
        return false;
    }

    public String getName() {
        return this.name;
    }

    public void setName(String s) {
        this.name = s;
    }

    @Override
    public Point2D getPosition() {
        return position;
    }

    @Override
    public int getLayer() {
        return this.Layer;
    }

    public void setLayer(int i) {
        this.Layer = i;
    }

    public void setPosition(Point2D p) {
        this.position = p;
    }

    public static GameElement createAGameElement(String[] element) {

        int x = Integer.parseInt(element[1]);
        int y = Integer.parseInt(element[2]);

        switch(element[0]) {

            case "Bat":
                return new Bat(new Point2D(x,y));

            case "Door":
                int x2 = Integer.parseInt(element[4]);
                int y2 = Integer.parseInt(element[5]);

                if( element.length == 6) {
                    return new Door( new Point2D(x,y), element[3], new Point2D(x2,y2));
                }

                return new Door(new Point2D(x,y), element[3], new Point2D(x2,y2), element[6]);

            case "Key":
                return new Key(new Point2D(x,y), element[3]);

            case "Sword":
                return new Sword(new Point2D(x,y));

            case "HealingPotion":
                return new HealingPotion(new Point2D(x,y));

            case "Thug":
                return new Thug(new Point2D(x,y));

            case "Armor":
                return new Armor(new Point2D(x,y));

            case "Skeleton":
                return new Skeleton(new Point2D(x,y));

            case "Treasure":
                return new Treasure(new Point2D(x,y));

            case "Scorpio":
                return new Scorpio(new Point2D(x,y));

            case "Thief":
                return new Thief(new Point2D(x,y));

            default:
                throw new IllegalArgumentException("Unknown GameElement " + element[0]);
        }
    }

    public GameElement viablePosition(Point2D p, Room r) {
        if(GameEngine.getInstance().getgui().isWithinBounds(p)) {
            if(r.notWall(p) == true) {
                if(GameEngine.getInstance().getHero().getPosition().equals(p) == false) {
                    for(GameElement GE: r.getActiveElements()) {
                        if(GE.getPosition().equals(p)) {
                            return GE;
                        }
                    }
                    return new Floor(p);
                }
                return GameEngine.getInstance().getHero();
            }
            return new Wall(p);
        }
        throw new IllegalStateException("The point in the room: "  + r.getName() + "acesses out of bounds");
    }


    public static void Movables(Hero h) {
        for(GameElement GE: GameEngine.getInstance().getCurrentRoom().getEnemis()) {
            if ( GE instanceof Movable ) {
                Point2D p1 = ((Movable) GE).Move(h.getPosition());
                GameElement GEp = GE.viablePosition(p1, GameEngine.getInstance().getCurrentRoom());
                if(GEp.getLayer() == 0) {
                    GE.setPosition(p1);
                }
                else {
                    if(GEp.getName().equals("Hero")) {
                        ((Movable) GE).attack(h);
                    }
                }
            }
        }
    }

    public void dropItemNear(GameElement GE) {
        List<Point2D> pointsNear = getPosition().getWideNeighbourhoodPoints();
        for(Point2D p: pointsNear) {
            GameElement GE1 = viablePosition(p, GameEngine.getInstance().getCurrentRoom());
            if(GE1.getName().equals("Floor")) {
                GE.setPosition(p);
                GameEngine.getInstance().addElement(GE);
                return;
            }
        }
        System.out.println("No space for hero to drop item: " + GE.getName());
    }
}
