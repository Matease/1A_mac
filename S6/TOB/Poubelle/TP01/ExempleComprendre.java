/** Comprendre les objets et les poignées sur la classe Point.
 * @author  Xavier Crégut
 * @version 1.6
 */
public class ExempleComprendre {

	/** Afficher un point précédé d'un texte.
	 * @param texte le texte à afficher
	 * @param p le point à afficher
	 */
	public static void afficher(String texte, Point p) {
		System.out.print(texte + " = ");
		p.afficher();
		System.out.println();
	}

	/** Méthode principale */
	public static void main(String[] args) {
		// Créer et afficher un point p1
		Point p1;		// déclarer une poignée sur un Point, cela ne créer pas un point, i
		// pointe sur rien à ce stade
		p1 = new Point(3, 4);	// créer un point et l'attacher à p1
			// On peut écrire les deux instructions précédentes sur la
			// même ligne.  Ceci évite d'oublier d'initialiser une
			// poignée.
			// on aurait pu écrire Point p1 = newp Point (3,4) au lieu d'écrire sur les deux lignes
		afficher("p1", p1);

		// Créer et afficher un point p2
		Point p2 = new Point(0, 0);  // On déclare des poignées et on
									 // crée des objets quand on veut.
		afficher("p2", p2);

		// Afficher la distance entre p1 et p2
		double d = p1.distance(p2);
		System.out.println("Distance de p1 à p2 : " + d);

		// Translater p1
		System.out.println("> p1.translater(6, -2);");
		p1.translater(6, -2);
		afficher("p1", p1);		// Qu'est ce qui est affiché ? P1 = (9,2)

		// Changer l'abscisse de p1 et afficher p1
		System.out.println("> p1.setX(0);");
		p1.setX(0);
		afficher("p1", p1);		// Qu'est ce qui est affiché ?  P1 = (0, 2)

		// Changer l'ordonnée de p1 et afficher p1
		System.out.println("> p1.setY(10);");
		p1.setY(10);
		afficher("p1", p1);
										// Dessiner l'état de la mémoire
		// Prendre une nouvelle poignée sur p1
		System.out.println("> Point p3 = p1;");
		Point p3 = p1;
		afficher("p3", p3);		// Qu'est ce qui est affiché ?
		afficher("p1", p1);		// Qu'est ce qui est affiché ?

		// Déplacer p3
		System.out.println("> p3.translater(100, 100);");
		p3.translater(100, 100);
		afficher("p3", p3);		// Qu'est ce qui est affiché ?

		// Afficher p1
		afficher("p1", p1);		// Qu'est ce qui est affiché ?

										// Dessiner l'état de la mémoire
		// Affectations entre poignées
		System.out.println("> p3 = new Point(123, 321);");
		p3 = new Point(123, 321);
		afficher("p3", p3);		// Qu'est ce qui est affiché ? P3 = (123, 321)
		afficher("p1", p1);		// Qu'est ce qui est affiché ? 

		System.out.println("> p1 = p2 = p3;");
		p1 = p2 = p3;
										// Dessiner l'état de la mémoire on affecte l'objet pointé par p3 à p2
										//P1 pointe sur l'objet pointé par p2, il point donc sur l'obet pointé par p2 et p3
		afficher("p1", p1);		// Qu'est ce qui est affiché ? p1 = (123, 321)
		afficher("p2", p2);		// Qu'est ce qui est affiché ? p2 = (123, 321)
		afficher("p3", p3);		// Qu'est ce qui est affiché ? p3 = (123, 321)

		// p1, p2 et p3 sont-ils des points différents ?
		System.out.println("> p1.translater(-123, -321);");
		p1.translater(-123, -321); // on ramène à l'ogigne p1, hors p2 et p3 pointent sur le même objet
		// donc on a donc p3 et p2 pointent vers (0,0)
		// les autres points ne sont plus accessibles, le "ramasse miette"  entre en jeux pour détruire ces objets
		// et libérer de la mémoire. C'est la méthode finalyse.
		afficher("p1", p1);		// Qu'est ce qui est affiché ? p1 = (0, 0)
		afficher("p2", p2);		// Qu'est ce qui est affiché ?
		afficher("p3", p3);		// Qu'est ce qui est affiché ?
		

		d  = new Point(5, 5).distance(new Point(8, 1));
		System.out.println("d = " + d);

							// Combien y a-t-il de points accessibles ?
	}
}
