package objects.ui;

import flixel.FlxG;
import flixel.FlxSprite;

/**
 * Object that can be created for making a sprite clickable.
 */
class ClickableSprite extends FlxSprite {

	/**
	 * Called when `this` clickable sprite is clicked on.
	 */
	public var onClick:Void -> Void = () -> {};

	/**
	 * Called when `this` clickable sprite is hovered on.
	 */
	public var onHover:Void -> Void = () -> {};

	/**
	 * Called when `this` clickable sprite's hover boundaries are no longer overlapping
	 * the mouse.
	 */
	public var onHoverLost:Void -> Void = () -> {};

	/**
	 * X bounds for the *left* side of `this` clickable sprite.
	 */
	public var bxl:Float;

	/**
	 * X bounds for the *right* side of `this` clickable sprite.
	 */
	public var bxr:Float;

	/**
	 * Y bounds for the *top* side of `this` clickable sprite.
	 */
	public var byt:Float;

	/**
	 * Y bounds for the *bottom* side of `this` clickable sprite.
	 */
	public var byb:Float;

	/**
	 * Is `this` current clickable sprite being hovered on?
	 */
	public var isHovered:Bool = false;

	/**
	 * Constructor.
	 * 
	 * @param x      The X position of `this` clickable sprite.
	 * @param y      The Y position of `this` clickable sprite.
	 */
	public function new(x:Float = 0, y:Float = 0) {
		super(x, y);
	}

	// -----------------------------
    //            METHODS
    // -----------------------------

	override function update(elapsed:Float) {
		super.update(elapsed);

		if (isHoveringOverMouse()) {
			if (!isHovered) {
				onHover();
				isHovered = true;
			}

			if (FlxG.mouse.justPressed) {
				onClick();
			}
		}

		if (!isHoveringOverMouse() && isHovered) {
			isHovered = false;
			onHoverLost();
		}
	}

	override function setPosition(x:Float = 0.0, y:Float = 0.0) {
		super.setPosition(x, y);
		updateHoverBounds();
	}

	/**
	 * Gets `this` clickable sprite's hover bounds as an array.
	 * @return The hover bounds as an array.
	 */
	public inline function getHoverBoundsArray():Array<Float> {
		return [bxl, bxr, byt, byb];
	}

	/**
	 * Sets the ***X*** hover bounds.
	 * 
	 * @param bxl Left X hover bound.
	 * @param bxr Right X hover bound.
	 */
	public function setHoverBoundsX(bxl:Float, bxr:Float):Void {
		this.bxl = bxl;
		this.bxr = bxr;
	}

	/**
	 * Sets the ***Y*** hover bounds.
	 * 
	 * @param byt Top Y hover bound.
	 * @param byb Bottom Y hover bound.
	 */
	public function setHoverBoundsY(byt:Float, byb:Float):Void {
		this.byt = byt;
		this.byb = byb;
	}

	/**
	 * Sets the hover bounds for all four sides of `this`
	 * clickable sprite. 
	 * 
	 * @param bxl Left X hover bound.
	 * @param bxr Right X hover bound.
	 * @param byt Top Y hover bound.
	 * @param byb Bottom Y hover bound.
	 */
	public function setHoverBounds(bxl:Float, bxr:Float, byt:Float, byb:Float):Void {
		this.bxl = bxl;
		this.bxr = bxr;
		this.byt = byt;
		this.byb = byb;
	}

	/**
	 * Reset the hover bounds to match `this` clickable sprite's hitbox.
	 */
	public function updateHoverBounds():Void {
		bxl = this.x;
		bxr = this.x + this.width;
		byt = this.y;
		byb = this.y + this.height;
	}

	/**
	 * Is `this` clickable sprite's hover bounds overlapping the mouse?
	 * 
	 * @return If the mouse is inside `this` clickable sprite's hover bounds.
	 */
	public inline function isHoveringOverMouse():Bool {
		return (FlxG.mouse.x >= bxl) && (FlxG.mouse.y >= byt) && (FlxG.mouse.y <= byb) && (FlxG.mouse.x <= bxr);
	}
}
