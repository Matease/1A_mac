import java.awt.Color;

/** Un segment est défini pas ses deux points qui constituent ses
 * extrémités.  Un segment peut être affiché et translaté.
 *
 * @author	Xavier Crégut
 * @version	1.9
 */
public class Segment {

	private Point extremite1;
	private Point extremite2;
	private Color couleur;

	/**  Construire un Segment à partir de ses deux points extrémités.
	 *  @param ext1	le premier point extrémité
	 *  @param ext2	le deuxième point extrémité
	 */
	public Segment(Point ext1, Point ext2) {
		this.extremite1 = ext1;
		this.extremite2 = ext2;
		this.couleur = Color.green;
	}

   /** Translater le segment.
	* @param dx déplacement suivant l'axe des X
	* @param dy déplacement suivant l'axe des Y
	*/
	public void translater(double dx, double dy) {
		//System.err.println("Segment.translater(double, double) non implantée");
		/*this.extremite1.x += dx;
		this.extremite1.y += dy;
		this.extremite2.x += dx;
		this.extremite2.y += dy; */
		extremite1.translater(dx, dy);
		extremite2.translater(dx, dy);

	}

	/** Obtenir la longueur du segment.
	 * @return la longueur du segment
	 */
	public double longueur() {
		//System.err.println("Segment.longueur() non implantée");
		this.extremite1.distance(extremite1, extremite2);
	}

	/** Afficher le segment.  Le segment est affiché sous la forme :
	 * <PRE>
	 *		[extremite1-extremite2]
	 * </PRE>
	 */
	public void afficher() {
		//System.err.println("Segment.afficher() non implantée");
		this.extremite1.afficher();
		this.extremite2.afficher();
	}

	/** Obtenir la couleur du segment.
	 * @return la couleur du segment
	 */
	public Color getCouleur() {
		return this.couleur;
	}

	/** Changer la couleur du segment.
	 * @param nouvelleCouleur nouvelle couleur
	 */
	public void setCouleur(Color nouvelleCouleur) {
		this.couleur = nouvelleCouleur;
	}

}
