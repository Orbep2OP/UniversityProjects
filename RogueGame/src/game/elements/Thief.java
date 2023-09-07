package game.elements;

import graphics.GameEngine;
import utils.Point2D;

public class Thief extends GameElement implements Movable {

	private int hitpoints;
	private GameElement stolenItem;

	public Thief(Point2D p) {
		super(p);
		super.setLayer(1);
		super.setName("Thief");
		this.hitpoints = 5;
		stolenItem = null;
	}

	@Override
	public Point2D Move(Point2D p) {

		int distanciaX = p.getX() - this.getPosition().getX();
		int distanciaY = p.getY() - this.getPosition().getY();

		int x = 0;
		int y = 0;

		if(stolenItem == null) {

			if( distanciaX == 0 && distanciaY == 0 ) {
				return super.getPosition();
			}

			if( distanciaX == 0 && distanciaY > 0) {
				x = super.getPosition().getX();
				y = (super.getPosition().getY() + 1);
				return new Point2D(x,y);
			}

			if( distanciaX == 0 && distanciaY < 0) {
				x = super.getPosition().getX();
				y = (super.getPosition().getY() - 1);
				return new Point2D(x,y);
			}

			if( distanciaY == 0 && distanciaX > 0) {
				x = (super.getPosition().getX() + 1);
				y = super.getPosition().getY();
				return new Point2D(x,y);
			}

			if( distanciaY == 0 && distanciaX < 0) {
				x = (super.getPosition().getX() - 1);
				y = super.getPosition().getY();
				return new Point2D(x,y);
			}

			int xAux = distanciaX - super.getPosition().getX();
			int yAux = distanciaY - super.getPosition().getY();

			if(Math.abs(xAux) <= Math.abs(yAux)) {
				if(distanciaX > 0) {
					x = (super.getPosition().getX() + 1);
					y = super.getPosition().getY();
					return new Point2D(x,y);
				}
				else {
					x = (super.getPosition().getX() - 1);
					y = super.getPosition().getY();
					return new Point2D(x,y);
				}
			}

			if(distanciaY > 0) {
				x = super.getPosition().getX();
				y = (super.getPosition().getY() + 1);
				return new Point2D(x,y);
			}

			x = super.getPosition().getX();
			y = (super.getPosition().getY() - 1);
			return new Point2D(x,y);

		}

		if( distanciaX == 0 && distanciaY > 0 && super.getPosition().getY()!= 0) {
			x = super.getPosition().getX();
			y = (super.getPosition().getY() - 1);
			return new Point2D(x,y);
		}

		if( distanciaX == 0 && distanciaY > 0 && super.getPosition().getY() == 0) {
			x = (super.getPosition().getX() + 1);
			y = (super.getPosition().getY());
			return new Point2D(x,y);
		}

		if( distanciaX == 0 && distanciaY < 0 && super.getPosition().getY()!= 9) {
			x = super.getPosition().getX();
			y = (super.getPosition().getY() + 1);
			return new Point2D(x,y);
		}

		if( distanciaX == 0 && distanciaY < 0 && super.getPosition().getY() == 9) {
			x = (super.getPosition().getX() - 1);
			y = (super.getPosition().getY());
			return new Point2D(x,y);
		}


		if( distanciaY == 0 && distanciaX > 0 && super.getPosition().getX() != 0) {
			x = (super.getPosition().getX() - 1);
			y = super.getPosition().getY();
			return new Point2D(x,y);
		}

		if( distanciaY == 0 && distanciaX > 0 && super.getPosition().getX() == 0) {
			x = super.getPosition().getX();
			y = (super.getPosition().getY() + 1);
			return new Point2D(x,y);
		}

		if( distanciaY == 0 && distanciaX < 0 && super.getPosition().getX() != 9) {
			x = (super.getPosition().getX() + 1);
			y = super.getPosition().getY();
			return new Point2D(x,y);
		}

		if( distanciaY == 0 && distanciaX < 0 && super.getPosition().getX() == 9) {
			x = super.getPosition().getX();
			y = (super.getPosition().getY() - 1);
			return new Point2D(x,y);
		}


		int xAux = distanciaX - super.getPosition().getX();
		int yAux = distanciaY - super.getPosition().getY();

		if(Math.abs(xAux) <= Math.abs(yAux)) {
			if(distanciaX > 0) {
				x = (super.getPosition().getX() - 1);
				y = super.getPosition().getY();
				return new Point2D(x,y);
			}
			else {
				x = (super.getPosition().getX() + 1);
				y = super.getPosition().getY();
				return new Point2D(x,y);
			}
		}

		if(distanciaY > 0) {
			x = super.getPosition().getX();
			y = (super.getPosition().getY() - 1);
			return new Point2D(x,y);
		}

		x = super.getPosition().getX();
		y = (super.getPosition().getY() + 1);
		return new Point2D(x,y);
	}

	@Override
	public void attack(GameElement GE) {
		GameEngine.getInstance().updatePoints(-5);
		((Hero) GE).attacked(this);
	}

	public GameElement steal() {
		int index = (int) ( Math.random() * (GameEngine.getInstance().getHero().getInventory().size()) );
		GameElement GE = GameEngine.getInstance().getHero().getInventory().get(index);
		GameEngine.getInstance().getHero().getInventory().remove(index);
		int i = GameEngine.getInstance().getSB().getIndexOfItemInInventoryBar(GE.getName());
		GameEngine.getInstance().getSB().removeFromStatusBar(i + 1);
		stolenItem = GE;
		return GE;
	}

	@Override
	public void attacked(GameElement GE) {
		if(((Hero) GE).hasItem("Sword")) {
			this.hitpoints = this.hitpoints - 2;
		}
		else {
			this.hitpoints = this.hitpoints - 1;
		}

		if(isDead()) {
			if(stolenItem != null) {
				dropItemNear(stolenItem);
			}
			GameEngine.getInstance().updatePoints(5);
			GameEngine.getInstance().removeElement(this);
		}
	}

	@Override
	public boolean isDead() {
		return (hitpoints <= 0);
	}
}
