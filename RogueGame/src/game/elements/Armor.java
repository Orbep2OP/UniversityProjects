package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class Armor extends GameElement implements Pickable {

    public Armor(Point2D p) {
        super(p);
        super.setLayer(1);
        super.setName("Armor");
    }

    @Override
    public void pick() {
        GameEngine.getInstance().updatePoints(1);
        GameEngine.getInstance().removeElement(this);
    }
}
