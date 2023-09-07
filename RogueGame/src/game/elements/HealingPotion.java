package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class HealingPotion extends GameElement implements Pickable {

	public HealingPotion(Point2D p) {
		super(p);
		super.setLayer(1);
		super.setName("HealingPotion");
	}

	@Override
	public void pick() {
		GameEngine.getInstance().updatePoints(1);
		GameEngine.getInstance().removeElement(this);
	}
}
